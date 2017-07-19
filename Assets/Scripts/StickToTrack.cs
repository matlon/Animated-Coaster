using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StickToTrack : MonoBehaviour {
    public MeshFilter leftTrack, rightTrack;
    //public Collider leftTrack, rightTrack;
    public float targetDistance;
    public float force;
    private Rigidbody rb;
    //public float damping;
	
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

	void FixedUpdate () {
        Vector3 leftClosestPoint = leftTrack.mesh.bounds.ClosestPoint(transform.position);
        Vector3 rightClosestPoint = rightTrack.mesh.bounds.ClosestPoint(transform.position);
        //Vector3 leftClosestPoint = leftTrack.ClosestPointOnBounds(transform.position);
        //Vector3 rightClosestPoint = rightTrack.ClosestPointOnBounds(transform.position);
        float leftDistance = Vector3.Distance(leftClosestPoint, transform.position);
        float rightDistance = Vector3.Distance(rightClosestPoint, transform.position);
        Vector3 leftDirVector = (transform.position - leftClosestPoint).normalized;
        Vector3 rightDirVector = (transform.position - rightClosestPoint).normalized;
        float leftForce = force * (targetDistance - leftDistance);
        float rightForce = force * (targetDistance - rightDistance);
        Vector3 forceVector = (leftForce * leftDirVector) + (rightForce * rightDirVector);
        rb.AddForce(forceVector);
    }
}
